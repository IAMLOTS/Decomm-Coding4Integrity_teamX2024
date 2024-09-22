import { sveltekit } from "@sveltejs/kit/vite";
import { readFileSync } from "fs";
import { join } from "path";
import type { UserConfig } from "vite";
import { defineConfig, loadEnv } from "vite";
import path from "path";

const network = process.env.DFX_NETWORK ?? "local";
let host: string;

if (network === "local") {
  host = "http://localhost:8000";
} else if (network === "ic") {
  host = "https://icp-api.io";
} else if (network === "playground") {
  host = "https://raw.icp0.io";
} else {
  host = "http://localhost:8000";
}

const readCanisterIds = ({
  prefix,
}: {
  prefix?: string;
}): Record<string, string> => {
  let canisterIdsJsonFile: string;

  if (network === "ic") {
    canisterIdsJsonFile = join(process.cwd(), "canister_ids.json");
  } else if (network === "local") {
    canisterIdsJsonFile = join(
      process.cwd(),
      ".dfx",
      "local",
      "canister_ids.json",
    );
  } else if (network === "playground") {
    canisterIdsJsonFile = join(
      process.cwd(),
      ".dfx",
      "playground",
      "canister_ids.json",
    );
  } else {
    canisterIdsJsonFile = join(
      process.cwd(),
      ".dfx",
      "local",
      "canister_ids.json",
    );
  }

  try {
    type Details = {
      ic?: string;
      local?: string;
    };

    const config: Record<string, Details> = JSON.parse(
      readFileSync(canisterIdsJsonFile, "utf-8"),
    );

    return Object.entries(config).reduce((acc, current: [string, Details]) => {
      const [canisterName, canisterDetails] = current;

      return {
        ...acc,
        [`${prefix ?? ""}${canisterName.toUpperCase()}_CANISTER_ID`]:
          canisterDetails[network as keyof Details],
      };
    }, {});
  } catch (e) {
    throw Error(`Could not get canister ID from ${canisterIdsJsonFile}: ${e}`);
  }
};

const config: UserConfig = {
  plugins: [sveltekit()],
  build: {
    target: "es2020",
  },
  optimizeDeps: {
    esbuildOptions: {
      define: {
        global: "globalThis",
      },
    },
    include: ["buffer"],
  },
  resolve: {
    alias: {
      $lib: path.resolve("./src/lib"),
    },
  },
};

export default defineConfig(({ mode }: UserConfig): UserConfig => {
  // Expand environment - .env files - with canister IDs
  process.env = {
    ...process.env,
    ...loadEnv(mode ?? "development", process.cwd()),
    ...readCanisterIds({ prefix: "VITE_" }),
    VITE_DFX_NETWORK: network,
    VITE_HOST: host,
  };

  return {
    ...config,
    // Backwards compatibility for auto generated types of dfx that are meant for webpack and process.env
    define: {
      "process.env": {
        ...readCanisterIds({}),
        DFX_NETWORK: network,
      },
      global: "globalThis",
      "global.Buffer": "globalThis.Buffer",
    },
  };
});
