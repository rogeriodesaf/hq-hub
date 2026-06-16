package br.com.hqhub.service;

import java.util.List;

import br.com.hqhub.dto.CadastroDenunciaAnuncioDTO;
import br.com.hqhub.dto.CadastroDenunciaUsuarioDTO;
import br.com.hqhub.dto.DenunciaAnuncioRespostaDTO;
import br.com.hqhub.dto.DenunciaUsuarioRespostaDTO;
import br.com.hqhub.entity.Anuncio;
import br.com.hqhub.entity.DenunciaAnuncio;
import br.com.hqhub.entity.DenunciaUsuario;
import br.com.hqhub.entity.Usuario;
import br.com.hqhub.exception.RecursoNaoEncontradoException;
import br.com.hqhub.exception.RegraNegocioException;
import br.com.hqhub.mapper.DenunciaMapper;
import br.com.hqhub.repository.AnuncioRepository;
import br.com.hqhub.repository.DenunciaAnuncioRepository;
import br.com.hqhub.repository.DenunciaUsuarioRepository;
import br.com.hqhub.repository.UsuarioRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

@ApplicationScoped
public class DenunciaService {

    private final DenunciaAnuncioRepository denunciaAnuncioRepository;
    private final DenunciaUsuarioRepository denunciaUsuarioRepository;
    private final AnuncioRepository anuncioRepository;
    private final UsuarioRepository usuarioRepository;
    private final UsuarioAutenticadoService usuarioAutenticadoService;
    private final DenunciaMapper denunciaMapper;

    public DenunciaService(
            DenunciaAnuncioRepository denunciaAnuncioRepository,
            DenunciaUsuarioRepository denunciaUsuarioRepository,
            AnuncioRepository anuncioRepository,
            UsuarioRepository usuarioRepository,
            UsuarioAutenticadoService usuarioAutenticadoService,
            DenunciaMapper denunciaMapper) {
        this.denunciaAnuncioRepository = denunciaAnuncioRepository;
        this.denunciaUsuarioRepository = denunciaUsuarioRepository;
        this.anuncioRepository = anuncioRepository;
        this.usuarioRepository = usuarioRepository;
        this.usuarioAutenticadoService = usuarioAutenticadoService;
        this.denunciaMapper = denunciaMapper;
    }

    @Transactional
    public DenunciaAnuncioRespostaDTO denunciarAnuncio(CadastroDenunciaAnuncioDTO dto) {
        Usuario denunciante = usuarioAutenticadoService.obterUsuario();
        Anuncio anuncio = anuncioRepository.findByIdOptional(dto.anuncioId())
                .orElseThrow(() -> new RecursoNaoEncontradoException("Anúncio não encontrado."));

        if (anuncio.getAnunciante().getId().equals(denunciante.getId())) {
            throw new RegraNegocioException("Não é possível denunciar o próprio anúncio.");
        }

        DenunciaAnuncio denuncia = denunciaMapper.paraEntidade(dto, denunciante, anuncio);
        denunciaAnuncioRepository.persist(denuncia);
        return denunciaMapper.paraResposta(denuncia);
    }

    @Transactional
    public DenunciaUsuarioRespostaDTO denunciarUsuario(CadastroDenunciaUsuarioDTO dto) {
        Usuario denunciante = usuarioAutenticadoService.obterUsuario();
        Usuario usuarioDenunciado = usuarioRepository.findByIdOptional(dto.usuarioDenunciadoId())
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário não encontrado."));

        if (usuarioDenunciado.getId().equals(denunciante.getId())) {
            throw new RegraNegocioException("Não é possível denunciar a si mesmo.");
        }

        DenunciaUsuario denuncia = denunciaMapper.paraEntidade(dto, denunciante, usuarioDenunciado);
        denunciaUsuarioRepository.persist(denuncia);
        return denunciaMapper.paraResposta(denuncia);
    }

    @Transactional
    public List<DenunciaAnuncioRespostaDTO> listarMinhasDenunciasAnuncios() {
        Usuario denunciante = usuarioAutenticadoService.obterUsuario();
        return denunciaAnuncioRepository.listarPorDenunciante(denunciante.getId())
                .stream()
                .map(denunciaMapper::paraResposta)
                .toList();
    }

    @Transactional
    public List<DenunciaUsuarioRespostaDTO> listarMinhasDenunciasUsuarios() {
        Usuario denunciante = usuarioAutenticadoService.obterUsuario();
        return denunciaUsuarioRepository.listarPorDenunciante(denunciante.getId())
                .stream()
                .map(denunciaMapper::paraResposta)
                .toList();
    }
}
