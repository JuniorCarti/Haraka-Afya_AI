// server.js
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { client } = require('./paypal');
const paypal = require('@paypal/checkout-server-sdk');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.post('/create-order', async (req, res) => {
  const request = new paypal.orders.OrdersCreateRequest();
  request.prefer('return=representation');
  request.requestBody({
    intent: 'CAPTURE',
    purchase_units: [{
      amount: {
        currency_code: 'USD',
        value: req.body.amount || '7.99'
      }
    }]
  });

  try {
    const order = await client().execute(request);
    res.status(200).json(order.result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.post('/capture-order', async (req, res) => {
  const orderId = req.body.orderID;
  const request = new paypal.orders.OrdersCaptureRequest(orderId);
  request.requestBody({});

  try {
    const capture = await client().execute(request);
    res.status(200).json(capture.result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(process.env.PORT || 5000, () => {
  console.log(`🚀 Server running on port ${process.env.PORT}`);
});
