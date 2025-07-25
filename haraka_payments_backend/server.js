// server.js
require("dotenv").config();
const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const { PAYPAL_CLIENT_ID, PAYPAL_SECRET, PAYPAL_API } = process.env;

app.post("/create-order", async (req, res) => {
  const { amount } = req.body;

  try {
    const basicAuth = Buffer.from(`${PAYPAL_CLIENT_ID}:${PAYPAL_SECRET}`).toString("base64");

    const accessTokenResponse = await axios.post(
      `${PAYPAL_API}/v1/oauth2/token`,
      "grant_type=client_credentials",
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          Authorization: `Basic ${basicAuth}`,
        },
      }
    );

    const accessToken = accessTokenResponse.data.access_token;

    const orderResponse = await axios.post(
      `${PAYPAL_API}/v2/checkout/orders`,
      {
        intent: "CAPTURE",
        purchase_units: [{
          amount: {
            currency_code: "USD",
            value: amount
          }
        }],
        application_context: {
          return_url: "https://example.com/success",
          cancel_url: "https://example.com/cancel"
        }
      },
      {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );

    res.json(orderResponse.data);
  } catch (error) {
    console.error(error?.response?.data || error.message);
    res.status(500).json({ error: "Failed to create PayPal order" });
  }
});

app.listen(3000, '0.0.0.0', () => {
  console.log("Server running on http://0.0.0.0:3000");
});
// Export the app for testing or other purposes