const { execSync } = require('child_process');
const fs = require('fs');

try {
  // Use HEAD^ because the last commit on main was the Adra-style UI overhaul
  // Wait, I made a commit "feat: Adra-style UI overhaul" which is HEAD
  // So the original is HEAD^
  const result = execSync('git --no-pager show HEAD^:lakepass_frontend/lib/utils/constants.dart', {
    cwd: 'c:\\Users\\Praveen Krishna\\Desktop\\Persistent Ventures',
    encoding: 'utf-8'
  });
  fs.writeFileSync('C:\\Users\\Praveen Krishna\\Desktop\\Persistent Ventures\\old_constants.txt', result);
} catch (e) {
  console.error(e);
}
