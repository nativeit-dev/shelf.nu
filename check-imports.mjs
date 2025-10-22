import { readFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const dirsToCheck = ['./app', './server', './scripts'];
const extensions = ['.ts', '.tsx'];
const results = [];

function searchFiles(dir) {
  try {
    const files = readdirSync(dir);
    
    for (const file of files) {
      const fullPath = join(dir, file);
      const stat = statSync(fullPath);
      
      if (stat.isDirectory() && !file.startsWith('.') && file !== 'node_modules') {
        searchFiles(fullPath);
      } else if (extensions.some(ext => file.endsWith(ext))) {
        try {
          const content = readFileSync(fullPath, 'utf8');
          // Look for imports with .js extensions
          const jsImportRegex = /from\s+['"](\.\.?\/[^'"]*\.js)['"]/g;
          const matches = [...content.matchAll(jsImportRegex)];
          
          if (matches.length > 0) {
            results.push({
              file: fullPath,
              matches: matches.map(m => m[1])
            });
          }
        } catch (e) {
          // Skip files that can't be read
        }
      }
    }
  } catch (e) {
    // Skip directories that can't be read
  }
}

for (const dir of dirsToCheck) {
  searchFiles(dir);
}

if (results.length > 0) {
  console.log('Found TypeScript files importing .js files:');
  for (const result of results) {
    console.log(`\n${result.file}:`);
    for (const match of result.matches) {
      console.log(`  - ${match}`);
    }
  }
} else {
  console.log('No .js imports found in TypeScript files.');
}
