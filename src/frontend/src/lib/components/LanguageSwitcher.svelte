<script>
    import { selectedLanguage } from "$lib/data/stores/languageStore";
    
    const languages = [
      { code: 'en', label: 'English' },
      { code: 'es', label: 'Español' },
      { code: 'fr', label: 'Français' },
      { code: 'zh', label: '中文' },
    ];
  
    function switchLanguage(event) {
      selectedLanguage.set(event.target.value);
    }
  </script>
  
  <select on:change={switchLanguage}>
    {#each languages as lang}
      <option value={lang.code}>{lang.label}</option>
    {/each}
  </select>
  