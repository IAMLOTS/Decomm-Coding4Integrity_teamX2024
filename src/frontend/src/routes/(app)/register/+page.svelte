<script lang="ts">
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label/index.js";
  import { Button } from "$lib/components/ui/button";
  import BG from "$lib/images/bg-2.jpg";
  import { selectedLanguage } from "$lib/data/stores/languageStore";
  import { translations } from "$lib/data/translations";
  import {
    loggedIn,
    registerStore,
    fullName,
    loginStore,
    isValidUser,
  } from "$lib/data/stores/stores.js";
  import { goto } from "$app/navigation";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { superForm, defaults } from "sveltekit-superforms/client";
  import { z } from "zod";
  import { zod } from "sveltekit-superforms/adapters";
  import Reload from "svelte-radix/Reload.svelte";

  // Import the Language Switcher component
  import LanguageSwitcher from "$lib/components/LanguageSwitcher.svelte";

  let formSubmitted = false;
  let lang = 'en';  // Default to English

  // Reactively bind the store value to lang
  $: lang = $selectedLanguage;

  function loginCheck() {
    $loginStore = true;
    $registerStore = false;
    goto("/login");
  }

  const newContactSchema = z.object({
    fullName: z.string().min(2).max(15),
  });

  const { form, errors, enhance, constraints, capture, restore } = superForm(
    defaults(zod(newContactSchema)),
    {
      SPA: true,
      validators: zod(newContactSchema),
      onSubmit() {
        formSubmitted = true;
      },
      async onUpdate({ form }) {
        if (form.valid) {
          await actorBackend.createUser(form.data.fullName);
          $fullName = form.data.fullName;
          $registerStore = false;
          $loggedIn = true;
          $isValidUser = true;
          formSubmitted = false;
          goto("/");
        }
      },
    },
  );

  export const snapshot = { capture, restore };
</script>

<svelte:head>
  <title>{translations[lang].createAccount} - DeComm</title>
  <meta name="description" content="DeComm Registration Page" />
</svelte:head>

<div class="grid grid-cols-12 min-h-screen max-h-screen w-full z-50">
  <div class="hidden lg:flex lg:col-span-6 w-full h-full bg-black relative">
    <div
      class="absolute inset-0 bg-cover"
      style="background-image: url({BG});"
    ></div>
  </div>
  <div class="col-span-12 lg:col-span-6 w-full h-full flex justify-center items-center">
    <div class="absolute right-10 top-10 flex gap-4 items-center">
      <!-- Language Switcher Component -->
      <LanguageSwitcher />
      <!-- Switch to Login Button -->
      <Button variant="outline" on:click={loginCheck}>
        {translations[lang].switchToLoginButton}
      </Button>
    </div>
    <div class="block text-center">
      <h1 class="font-semibold text-2xl mb-2">
        {translations[lang].createAccount}
      </h1>
      <p class="opacity-75">
        {translations[lang].enterNameToRegister}
      </p>
      <form method="POST" use:enhance>
        <div class="grid w-full max-w-sm items-center gap-1.5 text-start mt-5">
          <Label for="fullName">{translations[lang].fullName}</Label>
          <Input
            type="text"
            id="fullName"
            name="fullName"
            bind:value={$form.fullName}
            {...$constraints.fullName}
          />
          {#if $errors.fullName}
            <small class="text-red-700 mb-2">{$errors.fullName}</small>
          {/if}
          {#if !formSubmitted}
            <Button type="submit">{translations[lang].registerButton}</Button>
          {:else}
            <Button disabled>
              <Reload class="mr-2 h-4 w-4 animate-spin" />
              {translations[lang].pleaseWait}
            </Button>
          {/if}
        </div>
      </form>
    </div>
  </div>
</div>
