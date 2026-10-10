const {chromium}=require('playwright'),http=require('http'),fs=require('fs'),path=require('path'),assert=require('assert/strict');
const root=path.resolve(__dirname,'../../app/src/main/assets/bcg_ui');const server=http.createServer((req,res)=>{const f=path.join(root,req.url.split('?')[0]);if(!f.startsWith(root)||!fs.existsSync(f)){res.statusCode=404;return res.end();}res.setHeader('Content-Type',f.endsWith('.js')?'application/javascript':f.endsWith('.css')?'text/css':'text/html');res.end(fs.readFileSync(f));});
(async()=>{await new Promise(r=>server.listen(0,'127.0.0.1',r));const browser=await chromium.launch({executablePath:process.env.BCG_TEST_CHROME,headless:true,args:['--no-sandbox','--no-zygote','--single-process','--disable-crash-reporter','--disable-crashpad']});const context=await browser.newContext({viewport:{width:1536,height:691},hasTouch:true});const page=await context.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));await page.addInitScript(()=>{window.requests=[];window.BCG={send:s=>requests.push(JSON.parse(s))};});await page.goto(`http://127.0.0.1:${server.address().port}/index.html`);
await page.evaluate(()=>BCGUI.receive({type:'serverHud',text:'5000|500|100|100|Los Santos|0|0|80|0|100|100|0|1'}));
for(const size of [{width:1536,height:691},{width:960,height:540}]){
 await page.setViewportSize(size);assert.equal(await page.locator('#hud').isVisible(),false);assert.equal(await page.locator('#movement').isVisible(),false);assert.equal(await page.locator('[data-command="weapon"]').isVisible(),false);assert.equal(await page.locator('#hotbar43').isVisible(),false);
 const a=await page.locator('#actions').boundingBox();assert(a.x<size.width*.03&&a.y>size.height*.4&&a.x+a.width<size.width*.23);
 await page.evaluate(()=>BCGUI.receive({type:'dialog',id:810,style:2,title:'Lista longa',text:Array.from({length:100},(_,i)=>'Item '+i).join('\n'),left:'Escolher',right:'Voltar'}));
 assert.equal(await page.locator('#list .row').first().evaluate(n=>getComputedStyle(n).touchAction),'pan-y');
 const list=await page.locator('#list').boundingBox();const foot=await page.locator('#dialogCard footer').boundingBox();assert(foot.y+foot.height<=size.height);
 const cdp=await context.newCDPSession(page),x=list.x+list.width/2,y=list.y+list.height*.8;
 await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x,y}]});
 for(let i=1;i<=8;i++)await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x,y:y-i*14}]});
 await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});await page.waitForTimeout(200);
 assert(await page.locator('#list').evaluate(n=>n.scrollTop)>30,'finger gesture must scroll the list');
 await page.evaluate(()=>document.getElementById('list').scrollTop=99999);await page.locator('#list .row').last().click();await page.locator('#positive').click();
 const response=await page.evaluate(()=>requests.filter(r=>r.op==='dialog').at(-1));assert.equal(response.item,99);assert.equal(response.text,'Item 99');
 await page.evaluate(()=>BCGUI.receive({type:'gameMenu45',open:true}));assert.equal(await page.locator('#actions').isVisible(),false);await page.evaluate(()=>BCGUI.receive({type:'gameMenu45',open:false}));assert.equal(await page.locator('#actions').isVisible(),true);
}
await page.evaluate(()=>BCGUI.receive({type:'sessionReset'}));assert.equal(await page.locator('#actions').isVisible(),false);assert.deepEqual(errors,[]);console.log('PASS: native-only HUD/control policy, shortcuts below map, touch scrolling, last item response, fixed footer, menu/connection restoration at 1536x691 and 960x540. Server simulated.');await browser.close();server.close();})().catch(e=>{console.error(e);server.close();process.exit(1)});
