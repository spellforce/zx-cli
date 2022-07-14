rm -rf ./public
cd ../client
yarn build
cp -r ./build ../server/public
cd ../server