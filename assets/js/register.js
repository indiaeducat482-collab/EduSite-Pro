import { supabase } from './supabase-config.js';
const f=document.querySelector('#registerForm'),m=document.querySelector('#msg');
f.addEventListener('submit',async e=>{e.preventDefault();const {error}=await supabase.auth.signUp({email:email.value,password:password.value,options:{data:{full_name:name.value}}});m.textContent=error?error.message:'Account created. Check email confirmation if enabled.';});
