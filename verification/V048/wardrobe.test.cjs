const {chromium}=require('playwright'),http=require('http'),fs=require('fs'),path=require('path'),assert=require('assert/strict');
const root=path.resolve(__dirname,'../../app/src/main/assets/bcg_ui');const server=http.createServer((req,res)=>{const f=path.join(root,req.url.split('?')[0]);if(!f.startsWith(root)||!fs.existsSync(f)){res.statusCode=404;return res.end();}res.setHeader('Content-Type',f.endsWith('.js')?'application/javascript':f.endsWith('.css')?'text/css':'text/html');res.end(fs.readFileSync(f));});
(async()=>{await new Promise(r=>server.listen(0,'127.0.0.1',r));const browser=await chromium.launch({executablePath:process.env.BCG_TEST_CHROME,headless:true,args:['--no-sandbox','--no-zygote','--single-process','--disable-crash-reporter','--disable-crashpad']});const context=await browser.newContext({viewport:{width:1536,height:691}});const page=await context.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));await page.addInitScript(()=>{window.requests=[];window.BCG={send:s=>requests.push(JSON.parse(s))};});await page.goto(`http://127.0.0.1:${server.address().port}/index.html`);await page.evaluate(()=>document.body.style.background='#314238');
const packet=async text=>page.evaluate(text=>BCGUI.receive({type:'serverUi',text}),text);

await page.evaluate(()=>BCGUI.receive({type:'serverHud',text:'5000|500|100|100|Los Santos|0|0|80|0|100|100|0|1'}));
await packet('LOOK47|0|0|0|0');assert.equal(await page.locator('#wardrobe47').isVisible(),true);
assert.equal(await page.locator('#wardrobe47Form select').count(),4);
assert.equal(await page.locator('#movement').isVisible(),false);
await page.locator('#wardrobe47Form select').nth(0).selectOption('4');
await page.locator('#wardrobe47Form select').nth(1).selectOption('1');
await page.locator('#wardrobe47Save').click();
assert.equal(await page.evaluate(()=>requests.filter(r=>r.op==='command').at(-1).text),'/bcglook47 save 4 1 0 0');
assert.equal(await page.locator('#wardrobe47').isVisible(),true);
await packet('NOTICE|error|Falha ao salvar');assert.equal(await page.locator('#wardrobe47').isVisible(),true);
await packet('LOOK47SAVED');assert.equal(await page.locator('#wardrobe47').isVisible(),false);
assert.equal(await page.locator('#movement').isVisible(),false);
await packet('LOOK47|99|0|0|0');assert.equal(await page.locator('#wardrobe47').isVisible(),false);
await packet('LOOK47|0|0|0|5');await page.evaluate(()=>BCGUI.receive({type:'back'}));assert.equal(await page.locator('#wardrobe47').isVisible(),false);
await packet('LOOK47|1|2|3|4');
for(const size of [{width:1536,height:691},{width:960,height:540}]){await page.setViewportSize(size);const b=await page.locator('#wardrobe47 article').boundingBox();assert(b.x>=0&&b.x+b.width<=size.width);assert(b.y>=0&&b.y+b.height<=size.height);}
await page.screenshot({path:path.join(__dirname,'wardrobe47.png')});
await page.evaluate(()=>BCGUI.receive({type:'sessionReset'}));assert.equal(await page.locator('#wardrobe47').isVisible(),false);
assert.deepEqual(errors,[]);console.log('PASS: editor, validacao, comando de salvamento, erro preserva tela, confirmacao fecha, voltar, tamanhos e desconexao. Servidor simulado.');await browser.close();server.close();})().catch(e=>{console.error(e);server.close();process.exit(1)});
