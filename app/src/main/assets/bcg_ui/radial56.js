/* BCG V056 - menu radial, reutiliza comandos autenticados existentes. */
(()=>{'use strict';
const toggle=document.getElementById('radialToggle56'),overlay=document.getElementById('radialOverlay56'),close=document.getElementById('radialClose56');let open=false,lastTap=0;
function playable(){const actions=document.getElementById('actions');return actions&&!actions.hidden&&!document.body.classList.contains('gameMenu45')&&['dialogOverlay','selector','inventory43','wardrobe47','phoneFrame'].every(id=>document.getElementById(id).hidden);}
function setOpen(value){if(value&&!playable())return;open=!!value;overlay.hidden=!open;toggle.setAttribute('aria-expanded',String(open));if(window.BCG&&typeof BCG.send==='function')BCG.send(JSON.stringify({op:'modal',open}));if(typeof regions==='function')regions();}
function sync(){const active=playable();toggle.hidden=!active;if(!active&&open)setOpen(false);if(typeof regions==='function')regions();}
toggle.addEventListener('click',()=>setOpen(!open));close.addEventListener('click',()=>setOpen(false));overlay.addEventListener('click',e=>{if(e.target===overlay)setOpen(false)});
overlay.querySelectorAll('[data-radial56]').forEach(button=>button.addEventListener('click',()=>{const cmd=button.dataset.radial56;if(!open||Date.now()-lastTap<350)return;lastTap=Date.now();setOpen(false);const original=document.querySelector('#actions [data-command="'+cmd+'"]');if(original&&!original.hidden)original.click();}));
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&open){e.preventDefault();setOpen(false)}if((e.key==='h'||e.key==='H')&&playable()&&!e.repeat){e.preventDefault();setOpen(!open)}});
const observer=new MutationObserver(sync);['actions','dialogOverlay','selector','inventory43','wardrobe47','phoneFrame'].forEach(id=>{const el=document.getElementById(id);if(el)observer.observe(el,{attributes:true,attributeFilter:['hidden']})});sync();
})();
