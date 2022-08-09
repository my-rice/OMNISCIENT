const { Client } = require('pg')

const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

module.exports.connect = async () => {
  client.connect()
}

module.exports.getClient = () => {
  return client
}
