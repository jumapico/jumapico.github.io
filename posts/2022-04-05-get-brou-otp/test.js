import { Aes } from "./aes.js";
import crc32 from "crc-32/crc32.js";
import { hotp } from "otplib";

const key = "999999";
const ciphertext =
  "jNnbU15eXl5dMsxWZ5alkd9nFoWo1Eb1t0Izj4nh5PKVMGI0hOQLBQMv8k2t";

// validate seed
const plaintext = Aes.Ctr.decrypt(ciphertext, key, 256);
const [crc, seed] = plaintext.split(" ");

if (crc != crc32.str(seed)) {
  console.log("Invalid seed - abort");
  process.exit(1);
}
console.log("Seed: " + seed);

// generate token
const counter = Math.floor(new Date().getTime() / 40000);
const token = hotp.generate(seed, counter);
console.log("Code: " + token);
