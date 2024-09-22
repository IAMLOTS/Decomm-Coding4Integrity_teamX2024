import { writable } from 'svelte/store';

export const selectedLanguage = writable('en'); // Default to English

export const translations = {
    en: {
      signIn: "Sign In",
      enterName: "Enter your full name below to log into your account",
      fullName: "Full Name",
      loginButton: "Log In",
      registerButton: "Register",
      pleaseWait: "Please wait",
    },
    es: {
      signIn: "Iniciar sesión",
      enterName: "Ingrese su nombre completo a continuación para acceder a su cuenta",
      fullName: "Nombre completo",
      loginButton: "Iniciar sesión",
      registerButton: "Registrar",
      pleaseWait: "Por favor espera",
    },
    fr: {
      signIn: "Se connecter",
      enterName: "Entrez votre nom complet ci-dessous pour vous connecter à votre compte",
      fullName: "Nom complet",
      loginButton: "Se connecter",
      registerButton: "S'inscrire",
      pleaseWait: "Veuillez patienter",
    },
    zh: {
      signIn: "登录",
      enterName: "在下方输入您的全名以登录您的帐户",
      fullName: "全名",
      loginButton: "登录",
      registerButton: "注册",
      pleaseWait: "请稍候",
    },
  };
  