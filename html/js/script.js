const doc = document;
const plate = doc.getElementById('wrapper');
let currentKey = "";
let usingButtons = false;

this.window.addEventListener('load', e => {
    window.addEventListener('message', e => {
        switch (e.data.action) {
            case 'show':
                plate.style.display = 'flex';
                plate.style.opacity = '1';
                if (!usingButtons) {
                    doc.getElementById('btns').style.display = 'none';
                }
            break;

            case 'hide':
                plate.style.display = 'none';
                plate.style.opacity = '0';
                if (!usingButtons) {
                    doc.getElementById('btns').style.display = 'none';
                }
            break;

            case 'key':
                usingButtons = e.data.buttons;
                currentKey = e.data.key;
                doc.getElementById('title').textContent = e.data.title;
                if (e.data.chars) {
                    document.getElementById("text").maxLength = '8'
                    document.getElementsByName('text')[0].placeholder='ABCD1234';
                }
            break;
        }
    })
})

doc.getElementById('one').addEventListener('click', () => fetchNUI('getPlateText', doc.getElementById('text').value.toUpperCase()));

doc.getElementById('two').addEventListener('click', () => fetchNUI('close'));

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