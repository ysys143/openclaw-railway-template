import { definePluginEntry } from "openclaw/plugin-sdk/plugin-entry";

export default definePluginEntry({
  id: "env-guard",
  name: "Env Guard",
  register(api) {
    api.on("before_tool_call", async (event) => {
      const { toolName, params } = event;

      if (toolName === "read") {
        const filePath = params.path;
        if (typeof filePath === "string" && (filePath === ".env" || filePath.endsWith("/.env"))) {
          return {
            block: true,
            blockReason: "[Env Guard] .env 파일 직접 읽기가 차단되었습니다. (Node.js Hook)"
          };
        }
      }

      if (toolName === "exec") {
        const command = params.command;
        if (typeof command === "string" && command.includes(".env")) {
          return {
            block: true,
            blockReason: "[Env Guard] 명령어에 .env가 포함되어 차단되었습니다. (Node.js Hook)"
          };
        }
      }
    });
  }
});
