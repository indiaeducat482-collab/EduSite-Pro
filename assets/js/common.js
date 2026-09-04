import { supabase } from './supabase-config.js';

export async function requireUser(){
  const {data:{user}}=await supabase.auth.getUser();
  if(!user){ location.href='../owner-login.html'; throw new Error('Login required'); }
  return user;
}

export async function getMySchool(){
  const user=await requireUser();
  const {data,error}=await supabase.from('schools').select('*').eq('owner_id',user.id).limit(1).maybeSingle();
  if(error) throw error;
  return data;
}

export async function logout(){
  await supabase.auth.signOut();
  location.href='../index.html';
}
