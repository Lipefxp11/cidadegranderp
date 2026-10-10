'use strict';
let wardrobe47Open=false;
const wardrobe47Options=[
 ['Parte de cima',['Sem camisa','Camiseta branca','Regata preta','Camiseta preta','Moletom preto']],
 ['Parte de baixo',['Roupa íntima','Jeans azul','Bermuda cinza','Calça esportiva','Roupa íntima preta']],
 ['Calçados',['Descalço','Tênis preto','Tênis branco','Chinelo']],
 ['Cabelo',['Curto','Raspado','Degradê','Afro','Tranças','Raspado com barba']]
];
function wardrobe47Show(values){
 if(values.length!==4||values.some((v,i)=>!/^\d+$/.test(v)||Number(v)>=wardrobe47Options[i][1].length))return;
 if(phoneOpen||inv43.open)return;
 const form=document.getElementById('wardrobe47Form');form.replaceChildren();
 wardrobe47Options.forEach(([title,options],i)=>{
  const label=document.createElement('label'),select=document.createElement('select');label.textContent=title;
  select.name=String(i);select.setAttribute('aria-label',title);
  options.forEach((name,value)=>{const option=document.createElement('option');option.value=value;option.textContent=name;select.append(option);});
  select.value=String(Number(values[i]));label.append(select);form.append(label);
 });
 document.getElementById('wardrobe47Save').disabled=false;
 wardrobe47Open=true;document.getElementById('wardrobe47').hidden=false;document.body.classList.add('wardrobe47Open');modal(true);regions();
}
function wardrobe47Close(){
 wardrobe47Open=false;document.getElementById('wardrobe47').hidden=true;document.body.classList.remove('wardrobe47Open');
 modal(!!dialog||phoneOpen||inv43.open);regions();
}
document.getElementById('wardrobe47Cancel').onclick=wardrobe47Close;
document.getElementById('selectorWardrobe47').onclick=()=>send({op:'command',text:'/bcglook47 open'});
document.getElementById('wardrobe47Form').onsubmit=e=>{
 e.preventDefault();if(!wardrobe47Open)return;
 const values=[...e.currentTarget.querySelectorAll('select')].map(n=>Number(n.value));
 if(values.length!==4||values.some((v,i)=>!Number.isInteger(v)||v<0||v>=wardrobe47Options[i][1].length))return;
 send({op:'command',text:'/bcglook47 save '+values.join(' ')});
};
