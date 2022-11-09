import { existsSync } from 'fs';
import { basename } from 'path';

const getCurrentDirectoryBase = () => {
  return basename(process.cwd());
};

const directoryExists = (filePath) => {
  return existsSync(filePath);
};

export default { getCurrentDirectoryBase, directoryExists };
