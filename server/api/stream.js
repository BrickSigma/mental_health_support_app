import { StreamClient } from "@stream-io/node-sdk";
import { Router } from "express";
import { config } from 'dotenv';
import { Route } from "express";

config();

const apiKey = process.env.STREAM_API_KEY;
const secret = process.env.STREAM_SECRET_KEY;

const client = new StreamClient(apiKey, secret);

const router = Router();

router.post('/users', async (req, res) => {
    const userId = req.query.user_id;

    if (!userId) {
        res.status(400).send({ message: 'No user ID provided!' });
        return;
    }

    const newUser = {
        id: userId,
        role: 'user'
    }

    try {
        await client.upsertUsers([newUser]);
        res.status(200).end();
    } catch (error) {
        res.statusMessage = error;
        res.status(400).end();
    }

});

router.get('/tokens', async (req, res) => {
    const userId = req.query.user_id;

    if (!userId) {
        res.status(400).send({ message: 'No user ID provided!' });
        return;
    }

    const userToken = client.generateUserToken({
        user_id: userId,
        validity_in_seconds: 24 * 60 * 60,
    })

    res.json({
        userToken: userToken
    }).status(200).end();
});

router.delete('/users', async (req, res) => {
    const userId = req.query.user_id;

    if (!userId) {
        res.status(400).send({ message: 'No user ID provided!' });
        return;
    }

    try {
        await client.deleteUsers({ user_ids: [userId], user: "hard" });
        res.status(200).end();
    } catch (error) {
        res.statusMessage = error;
        res.status(400).end();
    }
});

export default router;
