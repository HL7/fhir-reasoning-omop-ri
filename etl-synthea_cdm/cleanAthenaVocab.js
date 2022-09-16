const fs = require("fs");

let vocabularyDirPath = `${__dirname}/vocabulary`;

const conceptCsvPath = `${vocabularyDirPath}/CONCEPT.csv`;
const editedCsvPath = `${vocabularyDirPath}/edited.csv`;
const notApplicableRegex = /(\t|^)NA(\t|$)/g;

console.log("Cleaning CONCEPT.csv");
let readStream = fs.createReadStream(conceptCsvPath);
let writeStream = fs.createWriteStream(editedCsvPath);

readStream.on("data", (chunk) => {
  let chunkString = chunk
    .toString()
    .replace(notApplicableRegex, (string) => string.replace("NA", "N/A"));
  writeStream.write(chunkString);
});

readStream.on("end", () => {
  console.log("Finished cleaning CONCEPT.csv");
  readStream.close();
  fs.unlinkSync(conceptCsvPath);
  fs.rename(editedCsvPath, conceptCsvPath, (err) => {
    if (err) {
      console.log(err);
    }
  });
  writeStream.close();
});
