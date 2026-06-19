import { Component, computed, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import {
  LucideBookOpen,
  LucideBot,
  LucideCalendarDays,
  LucideClipboardCheck,
  LucideGitCompare,
  LucideUpload,
  LucideLibrary,
  LucideLogOut,
  LucideSearch,
  LucideShoppingBag,
  LucideSparkles,
  LucideUsers,
} from '@lucide/angular';

import { AutenticacaoService } from './core/autenticacao.service';

@Component({
  selector: 'app-root',
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    LucideBookOpen,
    LucideBot,
    LucideCalendarDays,
    LucideClipboardCheck,
    LucideGitCompare,
    LucideUpload,
    LucideLibrary,
    LucideLogOut,
    LucideSearch,
    LucideShoppingBag,
    LucideSparkles,
    LucideUsers,
  ],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  private readonly roteador = inject(Router);
  readonly autenticacaoService = inject(AutenticacaoService);
  readonly usuario = this.autenticacaoService.usuario;
  readonly mostrarShell = computed(() => this.autenticacaoService.autenticado());

  sair() {
    this.autenticacaoService.sair();
    this.roteador.navigateByUrl('/entrar');
  }
}
