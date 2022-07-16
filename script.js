let labels2 = [
{
	label: "mbe",
	abbrev: "M",
	class: "mbe",
	descrip: "Minority-owned"
}, 
 { label: "wbe",
   abbrev: "W",
	class: "wbe", 
	descrip: "Woman-owned" 
}, 
  { 
  label: "disabled", 
  abbrev: "D",
	class: "disabled", 
	descrip: "Owned by member of the disability community" 
}, 
  { 
  	label: "african",
  	abbrev: "B",
  	class: "black",
  	descrip: "Black-owned"
  }, 
  { 
  	label: "hispanic",
  	abbrev: "H",
  	class: "hispanic",
  	descrip: "Hispanic-owned"
  },
  { 
  	label: "veteran",
  	abbrev: "V",
  	class: "veteran",
  	descrip: "Veteran-owned"
  },
  { 
  	label: "asian",
  	abbrev: "A",
  	class: "asian",
  	descrip: "Asian American-owned"
  },
  { 
  	label: "nativeamer",
  	abbrev: "NA",
  	class: "nativeamer",
  	descrip: "Native American-owned"
  },
  {
    label: "subasian",
    abbrev: "SA",
    class: "subasian",
    descrip: "Subcontinent Asian American-owned"
  }, 
]

/* 

function renderBadges(data) {

    let divv = document.createElement('div'); 
    divv.setAttribute("class", "circle-group")
    labels2.forEach(label => {
      
if(data.row[label.label] == "YES") { 
    divv.innerHTML += `
    <button class = 'btn ${label.class}'>
    <span>${label.abbrev}</span>
   <div class="tooltip">
    <span class="tooltext">${label.descrip}</span>
    </div>
    </button>`
} 
    }) 
    
      return divv.outerHTML;


};  */


function renderBadges(data) {

    let divv = document.createElement('div'); 
    divv.setAttribute("class", "circle-group")
    labels2.forEach(label => {
      
if(data.row[label.label]) { 
    divv.innerHTML += `
    <button class = 'btn badge ${label.class}' data-tooltip=${label.descrip}>
    ${label.abbrev}
 
    </button>`
} 
    }) 
      return divv.outerHTML;
}; 




jQuery(document).ready(function($) {
  
document.querySelectorAll("[data-tooltip]").forEach(tooltip => {
  tooltip.addEventListener("click",
function(el) { 
  console.log("clicked")
})
})
 
});
