local c = require("completions.common")

local nix_comps = {
  -- `nix --help`
  -- Help
  "help",
  "help-stores",
  -- Main
  "build",
  "develop",
  "flake",
  ["profile"] = {
    "add",
    "diff-closures",
    "history",
    "list",
    "remove",
    "rollback",
    "upgrade",
    "wipe-history",
  },
  "run",
  "search",
  "repl",
  -- Infrequent
  "bundle",
  "copy",
  "edit",
  "eval",
  "fmt",
  ["formatter"] = {
    "build",
    "run",
  },
  "log",
  "path-info",
  ["registry"] = {
    "add",
    "list",
    "pin",
    "remove",
    "resolve",
  },
  "why-depends",
  -- Utility/scripting
  ["config"] = {
    "check",
    "show",
  },
  "daemon",
  ["derivation"] = {
    "add",
    "show",
  },
  ["env"] = { "shell" },
  ["hash"] = {
    "convert",
    "file",
    "path",
    "to-base16",
    "to-base32",
    "to-base64",
    "to-sri",
  },
  ["key"] = {
    "convert-secret-to-public",
    "generate-secret",
  },
  ["nar"] = {
    "cat",
    "dump-path",
    "ls",
    "pack",
  },
  "print-dev-env",
  ["realisation"] = { "info" },
  ["store"] = {
    "add",
    "add-file",
    "add-path",
    "cat",
    "copy-log",
    "copy-sigs",
    "delete",
    "diff-closures",
    "dump-path",
    "gc",
    "info",
    "ls",
    "make-content-addressed",
    "optimise",
    "path-from-hash-part",
    "prefetch-file",
    "repair",
    "roots-daemon",
    "sign",
    "verify",
  },
  "upgrade-nix",
}

hilbish.completions.add("command.nix", function(query, ctx, fields)
  return c.sub_completion(query, ctx, fields, nix_comps)
end)

