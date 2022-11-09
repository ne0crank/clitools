import { Spinner } from 'clui';
import { Configstore } from 'configstore';
import { Octokit } from '@octokit/rest';
import { createBasicAuth } from '@octokit/auth-basic';
import { readFile } from 'fs/promises';

import { askGithubCredentials } from './inquirer.js';
const pkg = JSON.parse(await readFile(new URL('../package.json', import.meta.url)));
const conf = new Configstore(pkg.name);

let octokit;

const getInstance = () => {
  return octokit;
};

const getStoredGithubToken = () => {
  return conf.get('github.token');
};

const getPersonalAccessToken = async () => {
  const credentials = await askGithubCredentials();
  const status = new Spinner('Authenticating you, please wait...');
  status.start();

  const auth = createBasicAuth({
    username: credentials.username,
    password: credentials.password,
    async on2Fa() {

    },
    token: {
      scopes: ['user', 'public_repo', 'repo', 'repo:status'],
      note: 'ginit, the command-line tool for initializing Git repos'
    }
  });

  try {
    const res = await auth();

    if (res.token) {
      conf.set('github.token', res.token);
      return res.token;
    } else {
      throw new Error("Github token was not found in the response");
    }
  } finally {
    status.stop();
  }
};

export default { getInstance, getStoredGithubToken, getPersonalAccessToken };
