const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const source = fs.readFileSync(require('node:path').join(__dirname,'phone-r2.js'), 'utf8');
class Classes {
  constructor(node) { this.node=node; }
  contains(name) { return this.node.className.split(' ').includes(name); }
  add(name) { if(!this.contains(name)) this.node.className+=' '+name; }
  remove(name) { this.node.className=this.node.className.split(' ').filter(n=>n!==name).join(' '); }
}
const nodes={};
for(const id of ['view','content','home','screen','sheetShade']) {
  nodes[id]={innerHTML:'',className:id,style:{},scrollTop:0,fields:[],querySelectorAll(){return this.fields;},querySelector(){const match=this.innerHTML.match(/<h2>(.*?)<\/h2>/);return match?{textContent:match[1]}:null;}};
  nodes[id].classList=new Classes(nodes[id]);
}
function extract(name) {
  const start=source.indexOf('function '+name+'(');
  assert(start>=0,name);
  let end=source.indexOf('\nfunction ',start+1);
  if(end<0)end=source.length;
  return source.slice(start,end);
}
const context=vm.createContext({nodes,console});
vm.runInContext(`
const $=id=>nodes[id];
let current='home',history=[],pageHistory=[],rootRender=false,restoringPage=false,renderedChatId=null,chatId=null;
const header=title=>'<header class="topbar"><h2>'+title+'</h2></header>';
function applyTheme(){}
function renderHome(){}
function closeSheet(){$('sheetShade').classList.remove('open');}
function toast(message){throw new Error(message);}
${['snapshotPage','restorePage','show','open','home','back'].map(extract).join('\n')}
${['settings','bank','chat','social','music','maps','notes','phone','photos','camera','calendar','tasks','clock','store','health','wallet','rides','docs','browser','search','calc','control'].map(name=>`function ${name}(){show('${name}','body');}`).join('\n')}
function title(){return $('view').querySelector()?.textContent||'home';}
`,context);
const run=code=>vm.runInContext(code,context);
run("open('bank');show('Extrato','movimentações');back()");
assert.equal(run('title()'),'bank','Extrato volta à conta do banco');
run('back()');assert.equal(run('current'),'home','Raiz volta à tela inicial');
run("open('settings');show('Geral','');show('Redefinir','');back()");
assert.equal(run('title()'),'Geral');run('back()');assert.equal(run('title()'),'settings');
run("show('Geral','');open('bank');show('Extrato','');back();back()");
assert.equal(run('title()'),'Geral','Retorno entre apps preserva a subpágina anterior');
run('back()');assert.equal(run('title()'),'settings','Pilha anterior do app também é preservada');
run("home();open('bank');show('Transferir','');nodes.view.fields=[{id:'destino',name:'destino',value:'12345',checked:false}];nodes.content.scrollTop=82;show('Confirmar','');nodes.view.fields=[{id:'destino',name:'destino',value:'',checked:false}];back()");
assert.equal(nodes.view.fields[0].value,'12345','Voltar preserva formulário digitado');
assert.equal(nodes.content.scrollTop,82,'Voltar preserva rolagem');
run("nodes.sheetShade.classList.add('open');back()");
assert.equal(run('title()'),'Transferir','Voltar fecha a confirmação antes de mudar de tela');
assert(!nodes.sheetShade.classList.contains('open'));
run("home();open('chat');chatId=7;show('Contato','');back()");
assert.equal(run('title()'),'chat');assert.equal(run('chatId'),null,'Voltar sai da conversa e limpa o contato ativo');
run("home();open('bank');show('bank','saldo atualizado');back()");
assert.equal(run('current'),'home','Atualizar dados da tela não cria páginas extras');
console.log('9 cenários de navegação passaram.');
