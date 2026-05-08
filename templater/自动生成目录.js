// 自动为新笔记创建同名目录，并把笔记重命名为 index.md

async function createNoteFolder(tp) {

// 1. 获取当前文件路径

const file = tp.file.find_tfile(tp.file.path);

if (!file) return;

const vault = app.vault;

const filePath = file.path;

const fileName = file.basename;

const parentPath = file.parent.path;

// 如果已经在目录里，就跳过

if (filePath.includes(`${fileName}/index.md`)) {

return;

}

// 2. 创建同名文件夹

const folderPath = `${parentPath}/${fileName}`;

await vault.createFolder(folderPath);

// 3. 移动并重命名为 index.md

const newFilePath = `${folderPath}/index.md`;

await vault.rename(file, newFilePath);

// 4. 可选：自动打开 index.md

const newFile = vault.getFileByPath(newFilePath);

if (newFile) {

await app.workspace.getLeaf().openFile(newFile);

}

}

module.exports = createNoteFolder;