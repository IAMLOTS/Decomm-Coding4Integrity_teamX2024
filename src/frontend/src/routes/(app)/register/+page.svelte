<script lang="ts">
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label/index.js";
  import { Button } from "$lib/components/ui/button";
  import BG from "$lib/images/bg-2.jpg";
  import {
    loggedIn,
    registerStore,
    fullName,
    loginStore,
    isValidUser,
  } from "$lib/data/stores/stores.js";
  import { superForm, defaults } from "sveltekit-superforms/client";
  import { z } from "zod";
  import { zod } from "sveltekit-superforms/adapters";
  import Reload from "svelte-radix/Reload.svelte";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { goto } from "$app/navigation";

  let formSubmitted = false;

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

  function loginCheck() {
    $loginStore = true;
    $registerStore = false;
    goto("/login");
  }

  export const snapshot = { capture, restore };
</script>

<svelte:head>
  <title>Register - DeComm</title>
  <meta name="description" content="Donation Engine Home Page" />
</svelte:head>

<div class="grid grid-cols-12 min-h-screen max-h-screen w-full z-50">
  <div class="hidden lg:flex lg:col-span-6 w-full h-full bg-black relative">
    <div
      class="absolute inset-0 bg-cover"
      style="background-image: url({BG});"
    ></div>
  </div>
  <div
    class="col-span-12 lg:col-span-6 w-full h-full flex justify-center items-center"
  >
    <div class="absolute right-10 top-10">
      <Button variant="outline" on:click={loginCheck}>Login</Button>
    </div>
    <div class="block text-center">
      <h1 class="font-semibold text-2xl mb-2">Create an account</h1>
      <p class="opacity-75">Enter your fullname to register your account</p>
      <form method="POST" use:enhance>
        <div class="grid w-full max-w-sm items-center gap-1.5 text-start mt-5">
          <Label for="fullName">Full name</Label>
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
            <Button type="submit">Register</Button>
          {:else}
            <Button disabled>
              <Reload class="mr-2 h-4 w-4 animate-spin" />
              Please wait
            </Button>
          {/if}
        </div>
      </form>
    </div>
  </div>
</div>
