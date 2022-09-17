const fs = require('fs');
const path = require('path');
const axios = require('axios');
const {parse} = require('csv-parse/sync')
const NAMELOOKUP  = 'cohortNameLookup.csv'

// Get to-to-name lookup csv from disk 
const lookupFilePath = path.resolve(__dirname, NAMELOOKUP)
const lookupFile = fs.readFileSync(lookupFilePath)
const lookupJson = parse(lookupFile, { 
  columns: true,
  skip_empty_lines: true
})

async function getCohort(fileName) {
  return fs.promises
    .readFile(path.resolve(__dirname, 'cohorts', fileName))
    .then((file) => {
      // NOTE: Hardcoded trim the final 5 chars since we know all are JSON
      const id = fileName.slice(0,-5)
      const cohort = JSON.parse(file)
      const payload = { 
        id: id,
        name: lookupJson.find((row) => row.cohortId === id) ? lookupJson.find((row) => row.cohortId === id).cohortName : '',
        // expressionType: SIMPLE_EXPRESSION
        expression: cohort, 
      }
      axios.post('http://localhost:8080/WebAPI/cohortdefinition', payload)
      .then(function (response) {
        console.log(response);
      })
      .catch(function (error) {
        console.log(error.message);
      });
    })
    .catch((err) => {
      console.error("FileSystem getCohort read did not succeed:");
      console.error(err.msg);
      throw err;
    });
}

async function getAllCohorts() {
  return fs.promises
    .readdir(path.resolve(__dirname, 'cohorts'))
    .then((files) => {
      return Promise.all(
        files.map((fileName) => getCohort(fileName))
      );
    })
    .catch((err) => {
      console.error("FileSystem getAllCohorts read did not succeed:");
      console.error(err.msg);
      throw err;
    });
}

getAllCohorts()