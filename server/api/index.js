import express, { json } from 'express';
import cors from 'cors';
import router from './stream.js';

const app = express();

app.use(json());
app.use(cors());

app.use("/", router);

app.get("/", (req, res) => {
    res.send("Express on vercel");
});

app.listen(3000, () => console.log("Server is ready on port 3000"));

export default app;