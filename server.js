const express = require('express');
const bodyParser = require('body-parser');
const multer = require('multer');
const upload = multer({ dest: './uploads/' });
const logger = require('morgan');
const path = require('path');
const fs = require('fs');
const directoryPath = path.join(__dirname, '/uploads');
// Define port for app to listen on
const port = 8080;
const app =  express();
app.use(logger('dev'));  // Creating a logger (using morgan)
app.use(bodyParser());  // to use bodyParser (for text/number data transfer between clientg and server)
app.use(express.static('.'));  // making current directory as a static directory
app.use(express.json());
app.use(express.urlencoded({ extended: false })); //need to look
// GET / route for serving index.html file
app.get('/', (req, res) => {
    res.render('index.html');
});

app.get('/images', (req, res) =>{
    fs.readdir(directoryPath, (err, files) => {
        if (err) {
          return res.json([]);
        }
        return res.json(files);
      });
});
// POST /upload for single file upload

app.post('/upload', upload.single('myFile'), (req, res) => {
                       
  
    res.redirect('/')   // Redirecting back to the home local host:8080/
    
});
// To make the server live
app.listen(port, () => {
    console.log(`App is live on port ${port}`);
});
