import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const localTsc = join(root, "node_modules", ".bin", process.platform === "win32" ? "tsc.cmd" : "tsc");

function run(command, args) {
	const result = spawnSync(command, args, {
		cwd: root,
		stdio: "inherit",
		shell: false,
	});
	if (result.error) {
		console.error(`${command}: ${result.error.message}`);
		return 127;
	}
	return result.status ?? 1;
}

function commandExists(command) {
	const result = spawnSync(command, ["--version"], {
		cwd: root,
		stdio: "ignore",
		shell: false,
	});
	return !result.error && result.status === 0;
}

if (existsSync(localTsc)) {
	process.exit(run(localTsc, ["--noEmit"]));
}

if (commandExists("tsc")) {
	process.exit(run("tsc", ["--noEmit"]));
}

console.warn("tsc is not installed locally or globally in this shell.");
console.warn("Falling back to Wrangler dry-run validation for Worker syntax, bindings, and deploy config.");
process.exit(run("wrangler", ["deploy", "--dry-run"]));
