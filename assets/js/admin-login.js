import { supabase } from './supabase-config.js';

const f = document.querySelector('#loginForm');
const m = document.querySelector('#msg');

f.addEventListener('submit', async (e) => {
  e.preventDefault();

  const emailValue = document.querySelector('#email').value;
  const passwordValue = document.querySelector('#password').value;

  const { data, error } = await supabase.auth.signInWithPassword({
    email: emailValue,
    password: passwordValue
  });

  if (error) {
    m.textContent = error.message;
    return;
  }

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', data.user.id)
    .single();

  if (profileError) {
    m.textContent = profileError.message;
    return;
  }

  if (profile?.role !== 'super_admin') {
    await supabase.auth.signOut();
    m.textContent = 'This account is not a Super Admin account.';
    return;
  }

  window.location.href = 'admin/dashboard.html';
});
