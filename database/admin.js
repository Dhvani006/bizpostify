// Add new category to dropdown
function addCategory() {
    const input = document.getElementById('categoryInput');
    const category = input.value.trim();
    if (!category) {
        alert("Please enter a category name!");
        return;
    }

    fetch('addCategory.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'category=' + encodeURIComponent(category)
    })
    .then(res => res.text())
    .then(data => {
        alert(data);

        // Add to dropdown
        const select = document.getElementById('templateCategory');
        const option = document.createElement('option');
        option.value = category.toLowerCase().replace(/\s+/g, '_');
        option.text = category;
        select.add(option);

        input.value = "";
    });
}

// Upload and add Template image to selected category
function insertTemplate() {
    const category = document.getElementById('templateCategory').value;
    const fileInput = document.getElementById('templateImageInput');
    const file = fileInput.files[0];

    if (!category || !file) {
        alert("Please select a category and an image.");
        return;
    }

    const formData = new FormData();
    formData.append("templateImage", file);
    formData.append("category", category);

    fetch("addTemplate.php", {
        method: "POST",
        body: formData
    })
    .then(response => response.text())
    .then(data => {
        alert(data);
        console.log(data);
        fileInput.value = "";
    })
    .catch(error => {
        console.error("Error:", error);
        alert("Upload failed.");
    });
}



// Upload and show Frame image
function addFrameImage() {
    const fileInput = document.createElement('input');
    fileInput.type = 'file';
    fileInput.accept = 'image/*';
    fileInput.style.display = 'none';

    fileInput.onchange = (e) => {
        const file = e.target.files[0];
        if (file) {
            const formData = new FormData();
            formData.append('frameImage', file);

            fetch('uploadFrame.php', {
                method: 'POST',
                body: formData
            })
                .then(response => response.text())
                .then(data => {
                    console.log(data);

                    // After upload, display it
                    const reader = new FileReader();
                    reader.onload = (evt) => {
                        const box = document.createElement('div');
                        box.className = 'image-box';
                        box.innerHTML = `<img src="${evt.target.result}" alt="Frame Image">`;
                        document.getElementById('frameGrid').appendChild(box);
                    };
                    reader.readAsDataURL(file);
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Failed to upload frame image.');
                });
        }
    };

    document.body.appendChild(fileInput);
    fileInput.click();
}

// Optional: Fetch existing templates by category
function fetchTemplatesFromServer() {
    fetch('viewTemplates.php')
        .then(response => response.json())
        .then(data => {
            for (const [category, templates] of Object.entries(data)) {
                templates.forEach(filename => {
                    const img = document.createElement('img');
                    img.src = `Template_images/${filename}`;
                    img.alt = 'Template';

                    const box = document.createElement('div');
                    box.className = 'image-box';
                    box.appendChild(img);

                    document.getElementById('templateGrid').appendChild(box);
                });
            }
        })
        .catch(err => {
            console.error('Error fetching templates:', err);
        });
}

// Optional: auto-load existing templates on page load
// window.onload = fetchTemplatesFromServer;
