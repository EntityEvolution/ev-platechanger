const doc = document;
const plate = doc.getElementById('wrapper');
let currentKey = "";

this.window.addEventListener('load', e => {
    window.addEventListener('message', e => {
        switch (e.data.action) {
            case 'show':
                plate.style.display = 'flex';
                plate.style.opacity = '1';
            break;

            case 'hide':
                plate.style.display = 'none';
                plate.style.opacity = '0';
            break;

            case 'key':
                currentKey = e.data.key;
            break;
        }
    })
})

const fetchNUI = async (cbname, data) => {
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    };
    const resp = await fetch(`https://ev-platechanger/${cbname}`, options);
    return await resp.json();
}

doc.onkeyup = e => {
    if (e.key == currentKey) {
        const inp = doc.getElementById('text');
        fetchNUI('getPlateText', inp.value.toUpperCase());
    } else if (e.key == 'Escape') {
        plate.style.opacity = '0';
        fetchNUI('close');
    }
}