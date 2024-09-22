<script lang="ts">
  import "../app.css";
  import { onNavigate } from "$app/navigation";
  import { Toaster } from "svelte-sonner";
  import {
    loggedIn,
    registerStore,
    accountType,
    loginStore,
    fullName,
    isValidUser,
  } from "$lib/data/stores/stores";
  import { onMount, onDestroy } from "svelte";
  import { goto } from "$app/navigation";
  import Header from "$lib/components/modules/Header/Header.svelte";
  import { actorBackend } from "$lib/motokoImports/backend";

  let loaded = false;

  if (typeof window !== "undefined") {
    onNavigate((navigation) => {
      if (!(document as any).startViewTransition) return;
      return new Promise((resolve) => {
        (document as any).startViewTransition(async () => {
          resolve();
          await navigation.complete;
        });
      });
    });
  }

  const waitForWindowResolved = () =>
    new Promise<void>((resolve) => {
      if (typeof window !== "undefined") {
        resolve();
      } else {
        const interval = setInterval(() => {
          if (typeof window !== "undefined") {
            clearInterval(interval);
            resolve();
          }
        }, 50);
      }
    });

  async function handleLocalStorageChange() {
    console.log("Local storage changed. Unauthorized Triggering reMount.");
    await onMountFunctionality();
  }

  const storageListener = (event: StorageEvent) => {
    if (event.key === "fullName") {
      handleLocalStorageChange();
    }
  };

  async function onMountFunctionality() {
    if ($accountType.value !== "undefined") {
      $accountType.value = "Personal Account";
      loaded = true;
    }

    $isValidUser = await validateUser();

    if (loaded === true) {
      if ($loggedIn.value === true && $isValidUser) {
        if ($accountType.value === "Personal Account") {
          redirectTo("/");
        } else if ($accountType.value === "Business") {
          redirectTo("/admin");
        }
      } else if ($loggedIn.value === false && !$isValidUser) {
        if ($registerStore) {
          redirectTo("/login");
        }
      }
    }
  }

  async function validateUser() {
    if ($fullName.value === "") return false;
    const validUser = await actorBackend.getUserByName($fullName);
    if (validUser.length === 0) {
      $loggedIn = false;
      $accountType.value = "Personal Account";
      $loginStore = false;
      $registerStore = true;
      $fullName = "";
      goto("/register");
      return false;
    }
    return true;
  }

  onMount(async () => {
    await onMountFunctionality();
    if (typeof window !== "undefined") {
      await waitForWindowResolved();
      window.addEventListener("storage", storageListener);
    }
  });

  onDestroy(() => {
    if (typeof window !== "undefined") {
      window.removeEventListener("storage", storageListener);
    }
  });

  function redirectTo(path: string) {
    goto(path);
  }
</script>

{#if $loggedIn.value !== false && $isValidUser}
  <Header />
{/if}

<Toaster />

<slot />
