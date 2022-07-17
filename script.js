let labels2 = [{
        label: "mbe",
        abbrev: "M",
        class: "mbe",
        descrip: "Minority-owned"
    },
    {
        label: "wbe",
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

        if (data.row[label.label]) {

            tags.push({
                "class": label.class,
                "descrip": label.descrip
            });
            divv.innerHTML += `
    <button class = 'btn badge ${label.class}' type='button' data-toggle='tooltip' title='${label.descrip}'>
    ${label.abbrev}
 
    </button>`
        }
    })
    return {
        html: divv.outerHTML,
        tags: tags
    }
};


function renderDetails(rowInfo, column, state) {
    return `
            <div class='row-details'>
   <div class='company-header'>
     <h4>${rowInfo.values.company_name}</h4>
     <span class='company-address'>
       <i class='fas fa-map-marker-alt'></i> ${rowInfo.values.address_1}, ${rowInfo.values.city}, ${rowInfo.values.state} ${rowInfo.values.zip_code} </span>
   </div>
   <div class='company-body'>
     <div class='tag-group'>
       <strong>Tags: </strong> ${renderBodyTags(rowInfo)}
     </div>
     <div class='industry'>
       <strong>Primary NAICS Industry Description: </strong> ${rowInfo.values.naics_title}
     </div>
     <div class='contact-group'>
       <div>
         <span class='contact-item'>
           <i class='fas fa-phone-square-alt'></i> ${rowInfo.values.tel} </span>
         <span class='contact-item'>
           <i class='fas fa-desktop'></i> ${rowInfo.values.website==null ? 'No website available' : '<a href=' + rowInfo.values.website + ' target="_blank">' + rowInfo.values.website.split("http://")[1] + '</a>'} </span>
       </div>
     </div>
   </div>
   <hr />
   <div class='company-description'>
     <h4>Company Description</h4>
     <p>
       <em>${rowInfo.values.job_description}</em>
     </p>
   </div>
   <hr />
   <div class='company-footer'>
     <h4 style='font-size: 1.5rem; color:#696969'>Additional Information</h4>
     <div>
       <span style='display:block'>
         <strong>OSD Certification Number:</strong> ${rowInfo.values.osdcertnum} </span>
       <span class='contact-item' style='margin-top: 0rem; display:block'>
         <strong>ATTN:</strong> ${rowInfo.values.contact_name}, <a href='mailto:${rowInfo.values.email}'>${rowInfo.values.email}</a>
       </span>
     </div>
   </div>
 </div></div>`
}

window.addEventListener("DOMContentLoaded", function() {
document.querySelector("svg").classList.add("appear");
document.querySelector("#sidebarItemExpanded").classList.add("appear");
document.querySelectorAll(".box-header")[1].style.display="none";
})

function renderBodyTags(data) {
    const tags = renderBadges(data).tags;
    let str = []
    tags.forEach(tag => {
        str.push(`<span class = "${tag.class} body-badge">${tag.descrip}</span>`)
    })
    return str.join("")
}

function moreInfo(id, name) {
  Shiny.setInputValue("selected", id, {"priority":"event"})
  document.querySelector(".Reactable").scrollIntoView(); 
  document.querySelector(".rt-search").setAttribute("value",name)
}