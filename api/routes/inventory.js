// routes/inventory.js - CRUD endpoints for inventory items

const express = require('express');
const db = require('../db/db');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });
const router = express.Router();

function validateInventoryItem(data, { partial = false } = {}) {
    const errors = [];

    if (!partial || data.sku !== undefined) {
        if (!data.sku || typeof data.sku !== 'string' || data.sku.trim() === '') {
            errors.push('sku is required and must be a non-empty string');
        }
    }

    if (!partial || data.name !== undefined) {
        if (!data.name || typeof data.name !== 'string' || data.name.trim() === '') {
            errors.push('name is required and must be a non-empty string');
        }
    }

    if (data.quantity !== undefined) {
        const q = Number(data.quantity);
        if (!Number.isInteger(q) || q < 0) {
            errors.push('quantity must be a non-negative integer');
        }
    }

    if (data.unit_price !== undefined) {
        const p = Number(data.unit_price);
        if (Number.isNaN(p) || p < 0) {
            errors.push('unit_price must be a non-negative number');
        }
    }

    return errors;
}

// CREATE - add a new inventory item
router.post('/', (req, res) => {
    const { sku, name, category, quantity, unit_price, supplier } = req.body;

    const errors = validateInventoryItem(req.body);
    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    const stmt = db.prepare(`
        INSERT INTO inventory (sku, name, category, quantity, unit_price, supplier)
        VALUES (@sku, @name, @category, @quantity, @unit_price, @supplier)
    `);

    const result = stmt.run({ sku, name, category, quantity, unit_price, supplier });

    res.status(201).json({ id: result.lastInsertRowid });
});

// READ - list inventory items, with optional search/filter
router.get('/', (req, res) => {
    const { search, category } = req.query;

    let sql = 'SELECT * FROM inventory WHERE 1 = 1';
    const params = {};

    if (search) {
        sql += ' AND (name LIKE @search OR sku LIKE @search)';
        params.search = `%${search}%`;
    }

    if (category) {
        sql += ' AND category = @category';
        params.category = category;
    }

    sql += ' ORDER BY id';

    const items = db.prepare(sql).all(params);
    res.json(items);
});

// EXPORT - download all inventory as a CSV file
router.get('/export', (req, res) => {
    const items = db.prepare('SELECT * FROM inventory ORDER BY id').all();

    const columns = ['id', 'sku', 'name', 'category', 'quantity', 'unit_price', 'supplier', 'last_updated'];

    const escapeCsv = (value) => {
        const str = String(value ?? '');
        if (str.includes(',') || str.includes('"') || str.includes('\n')) {
            return '"' + str.replace(/"/g, '""') + '"';
        }
        return str;
    };

    const header = columns.join(',');
    const rows = items.map(item =>
        columns.map(col => escapeCsv(item[col])).join(',')
    );
    const csv = [header, ...rows].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="inventory_export.csv"');
    res.send(csv);
});

// IMPORT - bulk create/update inventory items from an uploaded CSV file
router.post('/import', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded. Send it as multipart/form-data under the field name "file".' });
    }

    const text = req.file.buffer.toString('utf8');
    const lines = text.split(/\r?\n/).filter(line => line.trim().length > 0);

    if (lines.length < 2) {
        return res.status(400).json({ error: 'CSV file has no data rows.' });
    }

    const header = lines[0].split(',').map(h => h.trim());
    const requiredCols = ['sku', 'name', 'quantity', 'unit_price'];
    const missing = requiredCols.filter(col => !header.includes(col));

    if (missing.length > 0) {
        return res.status(400).json({ error: `CSV is missing required columns: ${missing.join(', ')}` });
    }

    const upsert = db.prepare(`
        INSERT INTO inventory (sku, name, category, quantity, unit_price, supplier)
        VALUES (@sku, @name, @category, @quantity, @unit_price, @supplier)
        ON CONFLICT(sku) DO UPDATE SET
            name = excluded.name,
            category = excluded.category,
            quantity = excluded.quantity,
            unit_price = excluded.unit_price,
            supplier = excluded.supplier,
            last_updated = datetime('now')
    `);

    let imported = 0;
    const errors = [];

    for (let i = 1; i < lines.length; i++) {
        const values = lines[i].split(',').map(v => v.trim());
        const row = {};
        header.forEach((col, idx) => { row[col] = values[idx]; });

        try {
            upsert.run({
                sku: row.sku,
                name: row.name,
                category: row.category ?? null,
                quantity: parseInt(row.quantity, 10),
                unit_price: parseFloat(row.unit_price),
                supplier: row.supplier ?? null
            });
            imported++;
        } catch (err) {
            errors.push({ line: i + 1, message: err.message });
        }
    }

    res.json({ imported, totalRows: lines.length - 1, errors });
});

// READ - get a single inventory item by id
router.get('/:id', (req, res) => {
    const item = db.prepare('SELECT * FROM inventory WHERE id = ?').get(req.params.id);

    if (!item) {
        return res.status(404).json({ error: 'Item not found' });
    }

    res.json(item);
});

// DELETE - remove an inventory item
router.delete('/:id', (req, res) => {
    const result = db.prepare('DELETE FROM inventory WHERE id = ?').run(req.params.id);

    if (result.changes === 0) {
        return res.status(404).json({ error: 'Item not found' });
    }

    res.status(204).send();
});

// UPDATE - modify an existing inventory item
router.put('/:id', (req, res) => {
    const existing = db.prepare('SELECT * FROM inventory WHERE id = ?').get(req.params.id);

    if (!existing) {
        return res.status(404).json({ error: 'Item not found' });
    }

    const errors = validateInventoryItem(req.body, { partial: true });
    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    // Merge: use the new value if provided, otherwise keep what's already there
    const sku = req.body.sku ?? existing.sku;
    const name = req.body.name ?? existing.name;
    const category = req.body.category ?? existing.category;
    const quantity = req.body.quantity ?? existing.quantity;
    const unit_price = req.body.unit_price ?? existing.unit_price;
    const supplier = req.body.supplier ?? existing.supplier;

    db.prepare(`
        UPDATE inventory
        SET sku = @sku, name = @name, category = @category,
            quantity = @quantity, unit_price = @unit_price, supplier = @supplier,
            last_updated = datetime('now')
        WHERE id = @id
    `).run({ sku, name, category, quantity, unit_price, supplier, id: req.params.id });

    const updated = db.prepare('SELECT * FROM inventory WHERE id = ?').get(req.params.id);
    res.json(updated);
});

module.exports = router;