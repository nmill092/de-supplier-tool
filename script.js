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
	descrip: "Disability-owned" 
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

function renderBadges(data) {

    let divv = document.createElement('div'); 
    divv.setAttribute("class", "circle-group")
     let tags = []; 
    labels2.forEach(label => {
     
if(data.row[label.label]) { 
  
  tags.push({"class":label.class, "descrip": label.descrip});
    divv.innerHTML += `
    <button class = 'btn badge ${label.class}' data-tooltip=${label.descrip}>
    ${label.abbrev}
 
    </button>`
} 
    }) 
      return { 
        html: divv.outerHTML,
        tags: tags
      }
}; 


function renderBodyTags(data) {
  const tags = renderBadges(data).tags; 
  let str = []
  tags.forEach(tag => { 
    str.push(`<span class = "${tag.class} body-badge">${tag.descrip}</span>`)
  })
  return str.join("")
}



jQuery(document).ready(function($) {
  
document.querySelectorAll("[data-tooltip]").forEach(tooltip => {
  tooltip.addEventListener("click",
function(el) { 
  console.log("clicked")
})
})
 
});
