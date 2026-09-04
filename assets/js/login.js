import { supabase } from './supabase-config.js';
const f=document.querySelector('#loginForm'),m=document.querySelector('#msg');
f.addEventListener('submit',async e=>{e.preventDefault();const {data,error}=await supabase.auth.signInWithPassword({email:email.value,password:password.value});if(error){m.textContent=error.message;return}const {data:profile}=await supabase.from('profiles').select('role').eq('id',data.user.id).single();location.href=profile?.role==='super_admin'?'../../admin/dashboard.html':'../../owner/dashboard.html';});
