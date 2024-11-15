import { yellow, red } from 'chalk';
import { clear } from 'clear';
import { textSync } from 'figlet';
import {
  getCurrentDirectoryBase,
  directoryExists } from './lib/files.js';
import {
  getInstance,
  getStoredGithubToken,
  getPersonalAccessToken } from './lib/github.js';

// initialization
clear();
console.log(
  yellow(
    textSync('Ginit', { horizontalLayout: 'full' })
  )
);

// test folder for existence of .git folder
if (directoryExists('.git')) {
  console.log(red('Already a Git repository!'));
  process.exit();
}

// prompt for Github credentials
const run = async () => {
  let token = getStoredGithubToken();
  if (!token) {
    token = await getPersonalAccessToken();
  }
  console.log(token);
};
