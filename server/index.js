const keys = require('./keys');

const cors = require('cors');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser());

//Postgres setup
const { Pool } = require('pg');
const pgClinet = new Pool({
    user: keys.pgUser,
    host: keys.pgHost,
    database: keys.pgDatabase,
    password: keys.pgPassword,
    port: keys.pgPort,
});
pgClinet.on('error', () => console.log('Lost postgresql connection'));

pgClinet
    .query('CREATE TABLE IF NOT EXISTS values (number INT)')
    .catch(err => console.log(err))


//Redis setup
const redis = require('redis');
const redisClient = redis.createClient({
    host: keys.redisHost,
    port: keys.redisPort,
    retry_strategy: () => 1000,
});
const redisPublisher = redisClient.duplicate();

//Routing...
app.get('/', (req, res) => {
    res.send('Hello!');
});

app.get('/values/all', async (req, res) => {
    const values = await pgClinet.query('SELECT * FROM values');
    res.send(values.rows);
});

app.get('/values/current', async (req, res) => {
    redisClient.hgetall('values', (err, values) => {
        res.send(values);
    })
});

app.post('/values', async (req, res) => {
    const index = req.body.index;
    if (parseInt(index) > 40) {
        return res.status(422).send('Index out of bounds');
    }
    redisClient.hset('values', index, 'Nothing yet!');
    redisPublisher.publish('insert', index);
    pgClinet.query('INSERT INTO values(number) VALUES($1)', [index]);
    res.send({result: true});
});

app.listen(5000, err => {
    console.log('Listening @ 5000...');
});
