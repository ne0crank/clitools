import { start, get } from 'prompt';


let promptSchema = {
  properties: {
    UserName: {
      message: 'GitHub Username',
      required: true
    },
    Password: {
      message: 'GitHub Password',
      hidden: true,
      replace: '*'
    }
  }
};

start();

const askGithubCredentials = async () => {
    return await get(schema);
};

export default { askGithubCredentials };
