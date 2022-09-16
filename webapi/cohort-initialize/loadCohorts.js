const fs = require('fs');
const path = require('path');
const axios = require('axios');

async function getCohort(fileName) {
  return fs.promises
    .readFile(path.resolve(__dirname, 'cohorts', fileName))
    .then((file) => {
      axios.post('http://host.docker.internal:8080/WebAPI/cohortdefinition', JSON.parse(file))
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