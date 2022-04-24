const path = require('path');
const programDir = path.join(__dirname, 'program');
const generatedIdlDir = path.join(__dirname, 'js', 'idl');
const generatedSDKDir = path.join(__dirname, 'js', 'src', 'generated');
const PROGRAM_NAME = 'my_program_name';
const {Solita} = require('@metaplex-foundation/solita');
const {spawn} = require('child_process');

const shank = spawn('shank', ['idl', '--out-dir', generatedIdlDir, '--crate-root', programDir])
    .on('error', (err) => {
        console.error(err);
        if (err.code === 'ENOENT') {
            console.error(
                'Ensure that `shank` is installed and in your path, see:\n  https://github.com/metaplex-foundation/shank\n',
            );
        }
        process.exit(1);
    })
    .on('exit', () => {
        generateTypeScriptSDK();
    });

shank.stdout.on('data', (buf) => console.log(buf.toString('utf8')));
shank.stderr.on('data', (buf) => console.error(buf.toString('utf8')));

async function generateTypeScriptSDK() {
    console.error('Generating TypeScript SDK to %s', generatedSDKDir);
    const generatedIdlPath = path.join(generatedIdlDir, `${PROGRAM_NAME}.json`);

    const idl = require(generatedIdlPath);
    const gen = new Solita(idl, {formatCode: true});
    await gen.renderAndWriteTo(generatedSDKDir);

    console.error('Success!');

    process.exit(0);
}