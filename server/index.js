import express from "express";
import Stripe from "stripe";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const stripeSecret = process.env.STRIPE_SECRET_KEY;
if (!stripeSecret) {
    console.warn("Warning: STRIPE_SECRET_KEY is not set in .env");
}
const stripe = new Stripe(stripeSecret ?? "", { apiVersion: "2024-06-20" });

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.post("/payments/create-payment-intent", async (req, res) => {
    try {
        const { amount, currency = "usd", metadata } = req.body;
        if (typeof amount !== "number" || amount <= 0) {
            return res.status(400).json({ error: "Invalid amount" });
        }

        const intent = await stripe.paymentIntents.create({
            amount,
            currency,
            metadata,
            automatic_payment_methods: { enabled: true },
        });

        return res.json({ clientSecret: intent.client_secret });
    } catch (e) {
        return res.status(400).json({ error: e.message });
    }
});

const port = process.env.PORT || 3000;
const host = '0.0.0.0'; // Lắng nghe trên tất cả interfaces
app.listen(port, host, () => {
    console.log(`Server running on http://${host}:${port}`);
});

