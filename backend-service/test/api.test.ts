import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createApp } from "../src/app";
import { accountStore } from "../src/services/accountStore";

const app = createApp();

describe("backend api", () => {
  beforeEach(() => {
    accountStore.resetForTests();
  });

  it("returns health", async () => {
    const response = await request(app).get("/health").expect(200);
    expect(response.body.status).toBe("ok");
  });

  it("supports guest login, run validation, and upgrade purchase", async () => {
    const login = await request(app)
      .post("/api/v1/auth/guest")
      .send({ displayName: "Test Raider" })
      .expect(201);

    const token = login.body.accessToken;
    expect(token).toEqual(expect.any(String));

    const runStart = await request(app)
      .post("/api/v1/run/start")
      .set("Authorization", `Bearer ${token}`)
      .send({ routeId: "neon-fjord-01" })
      .expect(201);

    const report = await request(app)
      .post("/api/v1/run/report")
      .set("Authorization", `Bearer ${token}`)
      .send({
        runSessionId: runStart.body.runSession.runSessionId,
        sequence: 1,
        elapsedSeconds: 60,
        routeId: "neon-fjord-01",
        goldCollected: 100,
        enemiesDefeated: 10,
        rewardGroupsCollected: ["high-platform"]
      })
      .expect(200);

    expect(report.body.outcome).toBe("accept");
    expect(report.body.profile.currencies.gold).toBe(100);

    const purchase = await request(app)
      .post("/api/v1/upgrade/purchase")
      .set("Authorization", `Bearer ${token}`)
      .send({ upgradeId: "power.training" })
      .expect(200);

    expect(purchase.body.profile.currencies.gold).toBe(75);
    expect(purchase.body.profile.upgrades["power.training"]).toBe(1);
  });

  it("rejects impossible mutually exclusive route rewards", async () => {
    const login = await request(app).post("/api/v1/auth/guest").send({}).expect(201);
    const token = login.body.accessToken;
    const runStart = await request(app)
      .post("/api/v1/run/start")
      .set("Authorization", `Bearer ${token}`)
      .send({ routeId: "neon-fjord-01" })
      .expect(201);

    const report = await request(app)
      .post("/api/v1/run/report")
      .set("Authorization", `Bearer ${token}`)
      .send({
        runSessionId: runStart.body.runSession.runSessionId,
        sequence: 1,
        elapsedSeconds: 60,
        routeId: "neon-fjord-01",
        goldCollected: 100,
        enemiesDefeated: 10,
        rewardGroupsCollected: ["high-platform", "low-platform"]
      })
      .expect(200);

    expect(report.body.outcome).toBe("reject");
    expect(report.body.violations).toContain("mutually_exclusive_reward_groups");
  });
});

