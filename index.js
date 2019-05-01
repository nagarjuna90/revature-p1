
let learn = document.querySelector("#sections")

if(learn){

    fetch('/images')
    .then(res => res.json())
    .then(res => {
        res.forEach(image =>{
          const img = document.createElement('img')
          img.src = `/uploads/${image}`

          learn.appendChild(img)
        })
    });



}