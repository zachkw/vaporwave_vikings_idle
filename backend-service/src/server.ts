import { createApp } from "./app";
import { env } from "./config/env";

const app = createApp();

app.listen(env.port, () => {
  console.log(`Vaporwave Vikings backend listening on http://localhost:${env.port}`);
});

