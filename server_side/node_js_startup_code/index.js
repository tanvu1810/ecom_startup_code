const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');

const app = express();
const port = 3000;

app.use(bodyParser.json());
const uri = "mongodb://localhost:27017/test"
mongoose.connect(uri);
const db = mongoose.connection;
db.on('error', (error) => console.error(error));
db.once('open', () => console.log('Connected to Database'));
  
app.post('/', (req, res) => {
  const {name, age, email} = req.body
  const newUser = new User({ name: name, age: age, email: email});
  newUser.save();
  res.json('API is working');
});

app.delete('/:id', async (req, res) => {
  const id = req.params.id;
 await User.findByIdAndDelete(id);
  res.json('Delete successfully');
});

//TODO:  this
app.get('/', async (req, res) => {
  const users = await User.find();
  res.json(users);
});

// app.post('/:id', (req, res) => {
//   // const dataFormClient = req.body
//   // const userName = req.body.userName
//   // if(userName == "tan") {
//   //   res.json("user is logged in succes");
//   // }else {
//   //   res.json("user is not logged in succes");
//   // }
//   // console.log(userName);
//   const id = req.params.id
//   console.log(id);
//   res.json('User logged in');
// });


// app.post('/', (req, res) => {
//   const dataFormClient = req.body
//   const userName = req.body.userName
//   if(userName == "tan") {
//     res.json("user is logged in succes");
//   }else {
//     res.json("user is not logged in succes");
//   }
//   console.log(userName);
//   // const id = req.params.id
//   // console.log(id);
//   // res.json('User logged in');
// });

// app.delete('/:id', (req, res) => {
//   const id = req.params.id
//   console.log(id);
//   res.json("Deleted success")
// });

// app.put('/:id', (req, res) => {
//   const id = req.params.id
//   console.log(id);
//   res.json("Deleted success")
// });

app.listen(port, () => {
  console.log(`Server is running on :${port}`);
});

const { Schema, model } = mongoose;
const userSchema = new Schema({
  name: String,
  age: Number,
  email: String
});
const User = model('User', userSchema);
