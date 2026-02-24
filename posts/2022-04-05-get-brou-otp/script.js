import fetch from "node-fetch";
import * as readline from "readline";
import { Aes } from "./aes.js";
import crc32 from "crc-32/crc32.js";
import { hotp } from "otplib";

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function ask(question) {
  return new Promise((resolve) => {
    rl.question(question, resolve);
  });
}

async function retrieveEncryptedSeed(activationCode) {
  // retrieve encrypted seed
  const response = await fetch(
    `https://servicios.brou.com.uy/etoken/a.php?cupon=${activationCode}&callback=?`
  );
  const body = await response.text();

  // extract from response
  try {
    const [, encryptedSeed] = /"([^\"]+)"/.exec(body);
    return encryptedSeed;
  } catch (error) {
    console.error(`Error extracting encrypted seed from: \`${body}\``);
    console.error(error);
    process.exit(1);
  }
}

function obtainSeed(encryptedSeed, key) {
  // decrypt seed and validate
  const decryptedSeed = Aes.Ctr.decrypt(encryptedSeed, key, 256);
  const [crc, seed] = decryptedSeed.split(" ");

  if (crc != crc32.str(seed)) {
    console.error("Decrypted invalid seed: " + decryptedSeed);
    process.exit(1);
  }
  return seed;
}

function generatePassword(seed) {
  const counter = Math.floor(new Date().getTime() / 40000);
  return hotp.generate(seed, counter);
}

function help() {
  console.log(`Usage: get-seed|extract-seed|calculate-code|help

get-seed        Get seed from bank service using activation code.
extract-seed    Obtain seed from encrypted seed.
                This can be used in case when an error occur with the \`get-seed\`
                option and the encrypted seed is available.
calculate-code  Generate a password from the seed.
help            Show this help.
`);
}

async function command_get_seed() {
  const activationCode = await ask("Enter activation code: ");
  const key = await ask("Enter key: ");

  const encryptedSeed = await retrieveEncryptedSeed(activationCode);
  const seed = obtainSeed(encryptedSeed, key);
  console.log("Seed: " + seed);
}

async function command_extract_seed() {
  const encryptedSeed = await ask("Enter encrypted seed: ");
  const key = await ask("Enter key: ");

  const seed = obtainSeed(encryptedSeed, key);
  console.log("Seed: " + seed);
}

async function command_calculate_code() {
  const seed = await ask("Enter seed: ");
  const password = generatePassword(seed);
  console.log("Code: " + password);
}

async function main() {
  const argv = process.argv.slice(2); // remove `node script-name`
  if (argv.length == 1 && argv[0] == "get-seed") {
    await command_get_seed();
  } else if (argv.length == 1 && argv[0] == "extract-seed") {
    await command_extract_seed();
  } else if (argv.length == 1 && argv[0] == "calculate-code") {
    await command_calculate_code();
  } else if (argv.length == 1 && argv[0] == "help") {
    help();
  } else {
    console.error("Missing or unknown command. Try `help` command.");
    process.exit(1);
  }
  process.exit(0);
}

await main();
