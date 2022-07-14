RAILS_ENV=production rails db:migrate
rm -rf ./public
cd ../client
yarn build
cp -r ./build ../server/public
cd ../server
passenger stop -p 3005
passenger start -p 3005 -e production -d
